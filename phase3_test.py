import time
import multiprocessing

def test_func(i):
    data = bytearray(500000000)
    time.sleep(3)
    return i

if __name__ == '__main__':
    print('Phase 3: Starting 4-process test')
    pool = multiprocessing.Pool(4)
    results = pool.map(test_func, range(4))
    pool.close()
    pool.join()
    print('Phase 3: Test completed successfully')
