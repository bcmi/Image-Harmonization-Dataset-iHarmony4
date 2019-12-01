function idxSet = findHueInterval(vh, low, high)

if low<=high
    idxSet = (vh>=low & vh<high);
else  % low > high,  1 is in-between low and high
    idxSet = (vh>=low | vh<high);
end