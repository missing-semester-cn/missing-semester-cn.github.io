import random


def test_sorted(fn, iters=1000):
    for i in range(iters):
        l = [random.randint(0, 100) for i in range(0, random.randint(0, 50))]
        assert fn(l) == sorted(l)
        # print(fn.__name__, fn(l))


def insertionsort(array):

    for i in range(len(array)):
        j = i-1
        v = array[i]
        while j >= 0 and v < array[j]:
            array[j+1] = array[j]
            j -= 1
        array[j+1] = v
    return array


def quicksort(array):
    if len(array) <= 1:
        return array
    pivot = array[0]
    left = [i for i in array[1:] if i < pivot]
    right = [i for i in array[1:] if i >= pivot]
    return quicksort(left) + [pivot] + quicksort(right)


def quicksort_inplace(array, low=0, high=None):
    if len(array) <= 1:
        return array
    if high is None:
        high = len(array)-1
    if low >= high:
        return array

    pivot = array[high]
    j = low-1
    for i in range(low, high):
        if array[i] <= pivot:
            j += 1
            array[i], array[j] = array[j], array[i]
    array[high], array[j+1] = array[j+1], array[high]
    quicksort_inplace(array, low, j)
    quicksort_inplace(array, j+2, high)
    return array


if __name__ == '__main__':
    for fn in [quicksort, quicksort_inplace, insertionsort]:
        test_sorted(fn)
