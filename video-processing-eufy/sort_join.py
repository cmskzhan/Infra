def sort_list_by_second_part_of_substring(list_to_sort):
    list_to_sort.sort(key=lambda x: x.split("_")[1])
    return list_to_sort

# read text file each line into a list
with open('join.txt', 'r') as f:
    lines = f.readlines()

# sort the list by the second part of the substring
sorted_lines = sort_list_by_second_part_of_substring(lines)

# add substring to the beginning of each line
sorted_lines = ["file " + line for line in sorted_lines]
print(sorted_lines)

with open('join_sorted.txt', 'w') as f:
    for line in sorted_lines:
        f.write(line)
        