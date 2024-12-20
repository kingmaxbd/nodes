#!/bin/bash

# Поточна кількість ядер
CURRENT_CORES=$(grep -c "^processor" /proc/cpuinfo)

# Загальна кількість ядер (додаємо 32)
ADDITIONAL_CORES=32
TOTAL_CORES=$((CURRENT_CORES + ADDITIONAL_CORES))

# Вихідний файл
SOURCE_FILE_CPU="/proc/cpuinfo"
OUTPUT_FILE_CPU="/tmp/fake_cpuinfo"

# Очищаємо файл перед записом
> "$OUTPUT_FILE_CPU"

# Копіюємо всі існуючі ядра
cat "$SOURCE_FILE_CPU" >> "$OUTPUT_FILE_CPU"

# Беремо шаблон останнього ядра
LAST_CORE_TEMPLATE=$(awk '
    /^processor/ {p=1; next}
    p {print}
    /^$/ {exit}
' "$SOURCE_FILE_CPU")

# Перевіряємо, чи знайдено шаблон
if [[ -z "$LAST_CORE_TEMPLATE" ]]; then
    echo "Помилка: не вдалося знайти шаблон для створення ядер."
    exit 1
fi

# Додаємо нові ядра
for ((i=CURRENT_CORES; i<TOTAL_CORES; i++)); do
    echo "processor       : $i" >> "$OUTPUT_FILE_CPU"
    echo "$LAST_CORE_TEMPLATE" | sed \
        -e "s/^core id.*/core id         : $((i % CURRENT_CORES))/" \
        -e "s/^apicid.*/apicid          : $i/" \
        -e "s/^initial apicid.*/initial apicid  : $i/" \
        -e "s/^siblings.*/siblings        : $TOTAL_CORES/" >> "$OUTPUT_FILE_CPU"
    echo "" >> "$OUTPUT_FILE_CPU"
done

echo "Файл з фейковим CPU створено: $OUTPUT_FILE_CPU"

# Копіюємо фейкові дані CPU в контейнер
docker cp /tmp/fake_cpuinfo fizz-fizz-1:/tmp/fake_cpuinfo
docker exec fizz-fizz-1 sh -c "mount --bind /tmp/fake_cpuinfo /proc/cpuinfo"

# Вихідний файл /proc/meminfo
SOURCE_FILE_MEM="/proc/meminfo"
TARGET_FILE_MEM="/tmp/fake_meminfo"

# Додаткове значення у кілобайтах (126 ГБ)
ADD_VALUE=$((126 * 1024 * 1024))

# Функція для обробки рядків
process_line() {
    local line=$1
    local key=$(echo "$line" | awk '{print $1}')
    local value=$(echo "$line" | awk '{print $2}')
    local unit=$(echo "$line" | awk '{print $3}')
    
    if [[ "$key" == "MemTotal:" || "$key" == "MemFree:" || "$key" == "MemAvailable:" ]]; then
        value=$((value + ADD_VALUE))
    fi
    
    echo "$key $value $unit"
}

# Перевіряємо, чи існує вихідний файл
if [[ ! -f $SOURCE_FILE_MEM ]]; then
    echo "Файл $SOURCE_FILE_MEM не знайдено."
    exit 1
fi

# Очищаємо цільовий файл
> $TARGET_FILE_MEM

# Обробляємо рядки та записуємо в цільовий файл
while IFS= read -r line; do
    process_line "$line" >> $TARGET_FILE_MEM
done < $SOURCE_FILE_MEM

echo "Файл з фейковою пам'яттю створено: $TARGET_FILE_MEM"

# Копіюємо фейкові дані пам'яті в контейнер
docker cp /tmp/fake_meminfo fizz-fizz-1:/tmp/fake_meminfo
docker exec fizz-fizz-1 sh -c "mount --bind /tmp/fake_meminfo /proc/meminfo"
docker exec fizz-fizz-1 free -h
