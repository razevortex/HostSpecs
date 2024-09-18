param(
  # Our preferred encoding
  [parameter(Mandatory=$false)]
 
  [string]$path = ".\specs.json"
)


function getDrives(){
    $hdds = @() # List for the Drive Objects
    foreach ($item in Get-CimInstance Win32_LogicalDisk) { 
        while( $item.DeviceID ) {

            switch( $item.DriveType ) {
                3 {
                    $driveType = "HDD"
                    break;
                }
                5 {
                    $driveType = "Optical"
                    break;
                }
                default {
                    $driveType = "Other"
                }
            }

    $drive = [PSCustomObject]@{
                Label = $item.DeviceID
                Type = $driveType
                TotalSize = ("   {0:N2}" -f ($item.Size/1GB) + " GB  ")
                AvaibleSize = ("{0:N2}" -f ($item.FreeSpace/1GB) + " GB  ")
                }
    $hdds += $drive
    $item = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID = '$($driveletter):'"
    }
    } 
    return $hdds
}

function getRAM(){
    $rams = @() # List for the RAM Objects
    foreach ($item in Get-CimInstance CIM_PhysicalMemory) {
        $ram = [PSCustomObject]@{
                Label = $item.BankLabel
                Manufacturer = $item.Manufacturer
                Type = $item.Caption
                ModelNo = $item.PartNumber
                Clock = $item.Speed
                setClock = $item.ConfiguredClockSpeed
                TotalSize = ("   {0:N2}" -f ($item.Capacity/1GB) + " GB  ")
                }
        $rams += $ram
    }
    return $rams
}

function getGPU(){
    $gpus = @()
    foreach ($item in Get-CimInstance CIM_PCVideoController) {
        $gpu = [PSCustomObject]@{
                Chip = $item.VideoProcessor
                Manufacturer = $item.AdapterCompatibility
                Type = $item.Caption
                ID = $item.DeviceID
                Memory = ("   {0:N2}" -f ($item.AdapterRAM/1GB) + " GB  ")
                }
        $gpus += $gpu
    }
    return $gpus
}

function getCPU(){
    $cpus = @()
    $cpuObjs = Get-CimInstance WIN32_Processor -Property * | Select *
    foreach ($item in $cpuObjs){
        $cpu = [PSCustomObject]@{
                SystemID = $item.DeviceID
                ID = $item.ProcessorID
                Name = $item.Name
                Manufacturer = $item.Manufacturer
                Cores = $item.NumberOfCores
                Threads = $item.ThreadCount
                Clock = $item.MaxClockSpeed
                SocketDesignation = $item.SocketDesignation
                L2Cache = $item.L2CacheSize
                L3Cache = $item.L3CacheSize
                BitSystem = $item.DataWidth
                }
        $cpus += $cpu
    }
    return $cpus
}

function getAudio(){
    $soundController = @()
    $soundObjs = Get-CimInstance WIN32_SoundDevice -Property * | Select *
    foreach ($item in $soundObjs){
        $controller = [PSCustomObject]@{
            Name = $item.Name
            Manufacturer = $item.Manufacturer
            }
        $soundController += $controller        
    }
    return $soundController
}

function getNetwork(){
    $networkAdapter = @()
    $networkObjs = Get-CimInstance CIM_NetworkAdapter -Property * | Select *
    foreach ($item in $networkObjs){
        $controller = [PSCustomObject]@{
            Name = $item.Name
            Manufacturer = $item.Manufacturer
            MAC = $item.MACAddress
            Physical = $item.PhysicalAdapter
            Type = $item.AdapterType
            Bandwidth = ("   {0:N2}" -f ($item.Speed/1GB) + " GB  ")
            }
        $networkAdapter += $controller
    }
    return $networkAdapter
}

function getBios(){
    $bios = Get-CimInstance WIN32_Bios
    $item = [PSCustomObject]@{
                Manufacturer = $bios.Manufacturer
                Name = $bios.Name
                Version = $bios.Version
            }
    return @($item)
}

function getMainboard(){
    $main = Get-CimInstance WIN32_Baseboard
    $item = [PSCustomObject]@{
            Manufacturer = $main.Manufacturer
            Model = $main.Product
            }
    return @($item)
}
               
function getSystem(){
    $temp = Get-ComputerInfo -Property * | Select *
    $item = [PSCustomObject]@{
                              Type = $temp.CsPCSystemType
                              HostName = $temp.CsName
                              Domain = $temp.CsDomain
                            }
    return $item
}


function getHardware(){
    $Hardware = [PSCustomObject]@{
        Bios = getBios
        Mainboard = getMainboard
        Config = getSystem
        cpuList = getCPU
        ramList = getRAM
        driveList = getDrives
        gpuList = getGPU
        audioList = getAudio
        networkList = getNetwork
        }
    foreach ($item in $Hardware){
        $item
    }
    $json = $Hardware | ConvertTo-Json
    $json | Out-File -FilePath $path
}

getHardware;
