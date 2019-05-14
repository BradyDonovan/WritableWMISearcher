# WritableWMISearcher
A set of PowerShell functions that can be used to find writable WMI class properties.

# Usage
Several usage examples can be seen below. `Invoke-WMIClassWritablePropertySearcher` will return a `PSCustomObject` containing the writable class name, property, and datatype. For ease of use, the `-DataType` parameter of `Invoke-WMIClassWritablePropertySearcher` can tab-complete through all WMI datatypes, and the `-Namespace` parameter of `Get-WMIClassObject` can tab-complete through all WMI namespaces. Both functions support verbose messaging with `-Verbose`.
```powershell
Import-Module -Name C:\Path\To\Module\WMISearcher.psm1

$classObj = Get-WMIClassObject -Classname "Win32_OSRecoveryConfiguration"
Invoke-WMIClassWritablePropertySearcher -wmiClass $classObj -DataType String

$classesObj = Get-WMIClassObject -All
Invoke-WMIClassWritablePropertySearcher -wmiClasses $classesObj -DataType DateTime

$classesObj = Get-WMIClassObject -All -Namespace SecurityCenter
Invoke-WMIClassWritablePropertySearcher -wmiClasses $classesObj -DataType Boolean
```

# To Do
- Add the ability to search classes irrespective to datatype. For example, return all writable properties in `Win32_OSRecoveryConfiguration`.

# This Repository
Feel free to submit a pull request or issue if you find a bug. 

Happy hunting!
