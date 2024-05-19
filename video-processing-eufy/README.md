The work flow for a simple combining and editing mp4 files
1. copy all mp4 files into a folder
2. ls *.mp4 > join.txt
3. python sort_join.py 
this will generate join_sorted.txt that put all files in clonical order
4. ffmpeg -f concat -safe 0 -i join_sorted.txt -c copy combined.mp4
5. mv combined.mp4 <windows folder>
6. use a video editor such as microsoft clipchamp