# tindertexta

tindertexta is a tinder-like sorting tool for text files, allowing users to quickly categorize lines of text by swiping left or right using a simple keyboard interface.

## features

- **swipe interface**: use arrow keys to swipe left or right to categorize lines of text.
- **undo**: Quickly undo the last swipe.
- **progress saving**: automatically saves progress, allowing you to resume sorting later.

## installation

1. download the `tindertexta` script.
2. make it executable:
   ```
   chmod +x tindertexta
   ```
3.move it to a directory in your PATH, e.g.:
   ```
   sudo mv tindertexta /usr/local/bin/
   ```

## usage

basic usage:

```
tindertexta <input_file>
```

### controls

- left Arrow: Swipe left (categorize to left file)
- right Arrow: Swipe right (categorize to right file)
- up Arrow: Undo last action
- Q: Quit and save progress

### reset Progress

to reset progress for a specific file:

```
tindertexta <input_file> -reset
```

This will delete any existing output files and reset the progress tracker.

## file output

tindertexta generates two output files:

1. `<input_filename>-left.<extension>`: contains lines you swiped left on
2. `<input_filename>-right.<extension>`: contains lines you swiped right on

for example, if your input file is `example.txt`, the output files will be `example-left.txt` and `example-right.txt`.

## troubleshooting

1. **permission errors**: If you encounter permission errors when writing to output files, check the permissions of the directory where your input file is located.