import time
import multiprocessing

def test_func(i):
    data = bytearray(500000000)
    time.sleep(3)
    return i

if __name__ == '__main__':
    print('Phase 4: Starting 8-process test')
    pool = multiprocessing.Pool(8)
    results = pool.map(test_func, range(8))
    pool.close()
    pool.join()
    print('Phase 4: Test completed successfully')
