#!/bin/bash

set -e

CWD="$(cd $(dirname $0); pwd)"

rm -rf $CWD/EFI
rm -rf $CWD/downloads

mkdir -pv $CWD/EFI/BOOT
mkdir -pv $CWD/EFI/OC/ACPI
mkdir -pv $CWD/EFI/OC/Drivers
mkdir -pv $CWD/EFI/OC/Kexts
mkdir -pv $CWD/EFI/OC/Tools
mkdir -pv $CWD/downloads 

r=acidanthera/OpenCorePkg
t=$CWD/downloads/OpenCorePkg
v=$(curl -sL https://api.github.com/repos/$r/releases/latest | jq -r ".tag_name")
echo "OpenCore version: $v" | tee -a $CWD/EFI/buildinfo
curl -sL -o $CWD/downloads/OpenCore.zip https://github.com/$r/releases/download/$v/OpenCore-$v-RELEASE.zip
unzip -q $CWD/downloads/OpenCore.zip -d $t
cp -v $t/X64/EFI/BOOT/BOOTx64.efi           $CWD/EFI/BOOT/
cp -v $t/X64/EFI/OC/Drivers/OpenRuntime.efi $CWD/EFI/OC/Drivers/
cp -v $t/X64/EFI/OC/Tools/OpenShell.efi	    $CWD/EFI/OC/Tools/
cp -v $t/X64/EFI/OC/OpenCore.efi            $CWD/EFI/OC/

r=acidanthera/OcBinaryData
t=$CWD/downloads/OcBinaryData
git clone https://github.com/$r.git $t
echo "OcBinaryData version: $(git -C $t describe --always)"
cp -v $t/Drivers/HfsPlus.efi $CWD/EFI/OC/Drivers/

r=acidanthera/Lilu
t=$CWD/downloads/Lilu
v=$(curl -sL https://api.github.com/repos/$r/releases/latest | jq -r ".tag_name")
echo "Lilu version: $v" | tee -a $CWD/EFI/buildinfo
curl -sL -o $CWD/downloads/Lilu.zip https://github.com/$r/releases/download/$v/Lilu-$v-RELEASE.zip
unzip -q $CWD/downloads/Lilu.zip -d $t
cp -rv $t/Lilu.kext $CWD/EFI/OC/Kexts/

r=acidanthera/VirtualSMC
t=$CWD/downloads/VirtualSMC
v=$(curl -sL https://api.github.com/repos/$r/releases/latest | jq -r ".tag_name")
echo "VirtualSMC version: $v" | tee -a $CWD/EFI/buildinfo
curl -sL -o $CWD/downloads/VirtualSMC.zip https://github.com/$r/releases/download/$v/VirtualSMC-$v-RELEASE.zip
unzip -q $CWD/downloads/VirtualSMC.zip -d $t
cp -rv $t/Kexts/SMCBatteryManager.kext $CWD/EFI/OC/Kexts/
cp -rv $t/Kexts/SMCDellSensors.kext    $CWD/EFI/OC/Kexts/
cp -rv $t/Kexts/SMCProcessor.kext      $CWD/EFI/OC/Kexts/
cp -rv $t/Kexts/VirtualSMC.kext        $CWD/EFI/OC/Kexts/

r=acidanthera/WhateverGreen
t=$CWD/downloads/WhateverGreen
v=$(curl -sL https://api.github.com/repos/$r/releases/latest | jq -r ".tag_name")
echo "WhateverGreen version: $v" | tee -a $CWD/EFI/buildinfo
curl -sL -o $CWD/downloads/WhateverGreen.zip https://github.com/$r/releases/download/$v/WhateverGreen-$v-RELEASE.zip
unzip -q $CWD/downloads/WhateverGreen.zip -d $t
cp -rv $t/WhateverGreen.kext $CWD/EFI/OC/Kexts/

r=acidanthera/AppleALC
t=$CWD/downloads/AppleALC
v=$(curl -sL https://api.github.com/repos/$r/releases/latest | jq -r ".tag_name")
echo "AppleALC version: $v" | tee -a $CWD/EFI/buildinfo
curl -sL -o $CWD/downloads/AppleALC.zip https://github.com/$r/releases/download/$v/AppleALC-$v-RELEASE.zip
unzip -q $CWD/downloads/AppleALC.zip -d $t
cp -rv $t/AppleALC.kext $CWD/EFI/OC/Kexts/

r=acidanthera/VoodooPS2
t=$CWD/downloads/VoodooPS2Controller
v=$(curl -sL https://api.github.com/repos/$r/releases/latest | jq -r ".tag_name")
v=${v#v}
echo "VoodooPS2 version: $v" | tee -a $CWD/EFI/buildinfo
curl -sL -o $CWD/downloads/VoodooPS2Controller.zip https://github.com/$r/releases/download/v$v/VoodooPS2Controller-$v-RELEASE.zip
unzip -q $CWD/downloads/VoodooPS2Controller.zip -d $t
cp -rv $t/VoodooPS2Controller.kext $CWD/EFI/OC/Kexts/

r=VoodooI2C/VoodooI2C
t=$CWD/downloads/VoodooI2C
v=$(curl -sL https://api.github.com/repos/$r/releases/latest | jq -r ".tag_name")
echo "VoodooI2C version: $v" | tee -a $CWD/EFI/buildinfo
curl -sL -o $CWD/downloads/VoodooI2C.zip https://github.com/$r/releases/download/$v/VoodooI2C-$v.zip
unzip -q $CWD/downloads/VoodooI2C.zip -d $t
cp -rv $t/VoodooI2C.kext    $CWD/EFI/OC/Kexts/
cp -rv $t/VoodooI2CHID.kext $CWD/EFI/OC/Kexts/

git clone https://github.com/acpica/acpica $CWD/downloads/acpica
CFLAGS="-Wno-dangling-pointer" make -C $CWD/downloads/acpica -j $(nproc) iasl
iasl=$CWD/downloads/acpica/generate/unix/bin/iasl

$iasl $CWD/AcpiSource/SSDT-EC-USBX.dsl
$iasl $CWD/AcpiSource/SSDT-PLUG.dsl
$iasl $CWD/AcpiSource/SSDT-AWAC-DISABLE.dsl
$iasl $CWD/AcpiSource/SSDT-PNLF.dsl
cp -v $CWD/AcpiSource/*.aml $CWD/EFI/OC/ACPI/
cp -v $CWD/config.plist     $CWD/EFI/OC/

rm -rfv $CWD/EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooInput.kext
rm -rfv $CWD/EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Mouse.kext
rm -rfv $CWD/EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Trackpad.kext
rm -rfv $CWD/EFI/OC/Kexts/VoodooI2C.kext/Contents/PlugIns/VoodooInput.kext/Contents/_CodeSignature
