$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
& "C:\Users\fadye\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\avdmanager.bat" create avd -n "Galaxy_S24_Ultra" -d "pixel_9_pro" --package "system-images;android-36.1;google_apis_playstore;x86_64"
