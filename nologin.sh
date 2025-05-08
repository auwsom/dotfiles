#!/bin/bash
sed -i 's,root:/usr/sbin/nologin/,root:/bin/bash/,' /etc/passwd
#sed -i 's,root:/usr/bin/bash,root:/usr/sbin/nologin,' /etc/passwd
