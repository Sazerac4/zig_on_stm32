## Build

```bash
# Build
cmake --preset=Debug .
cd build/Debug
make
# Upload using stlink-tools
st-flash --reset --freq=4000k --format=ihex write build/Debug/*.hex
```
