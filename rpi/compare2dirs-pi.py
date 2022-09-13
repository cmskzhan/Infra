
# compare two folders recursively
import os
import glob
import click

def compare_folders(folder1, folder2):
    '''Only works when comparing paths has * in last folder
    eg folder1 = "/mnt/4thdd/download/18plus/thread*", folder2 = "/mnt/usbdisk/n/pix/thread*" '''
    # l1 = glob.glob(folder1 + "/**", recursive=True)
    # l2 = glob.glob(folder2 + "/**", recursive=True)
    ld1 = glob.glob(folder1)
    ld2 = glob.glob(folder2)

    for d1 in ld1:
        for d2 in ld2:
            if d1.split("/")[-1] == d2.split("/")[-1]:
                print(f"Comparing {d1} and {d2}")
                compare_files_sizes(d1, d2)
                compare_files_sizes(d2, d1)
                



def compare_files_sizes(dir1, dir2) -> None:
    recursive_list1 = os.walk(dir1)
    recursive_list2 = os.walk(dir2)
    for (dirpath, dirnames, filenames) in recursive_list1:
        for filename in filenames:
            file1 = os.path.join(dirpath, filename)
            
            # replace substring in filename
            file2 = file1.replace(dir1, dir2)
            # check if file2 exists
            if os.path.exists(file2):
                # compare files
                if os.path.getsize(file1) != os.path.getsize(file2):
                    click.secho(f"File {file1} and {file2} are different", fg="red")
                    
            else:
                click.secho(f"{file2} does not exist", fg="red", bold=True)
                


if __name__ == "__main__":
    #compare_files(dir1, dir2)
    input_source_dir = input("Enter source directory: ")
    input_target_dir = input("Enter target directory: ")

    if "*" in input_source_dir or "*" in input_target_dir:     # if input contains asterisk, use glob
        compare_folders(input_source_dir, input_target_dir)
    else:
        compare_files_sizes(input_source_dir, input_target_dir)


