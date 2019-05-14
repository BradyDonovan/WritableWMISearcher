function Invoke-WMIClassWritablePropertySearcher {
    <#
    .SYNOPSIS
    Search for writable properties in WMI.
    
    .DESCRIPTION
    Search for writable properties in WMI by examining ManagementClass objects and looking at qualifier objects for keyword 'write' and a desired datatype.
    
    .PARAMETER DataType
    Datatype to look for. Ex: String, Boolean, Datetime, SInt64
    
    .PARAMETER wmiClass
    If passing a single WMI class object to the function, use this. Expects a System.Management.ManagementClass type object.
    
    .PARAMETER wmiClasses
    If passing multiple WMI class objects to the function, use this. Expects a System.Object[] (array) type object.
    
    .EXAMPLE
    $classObj = Get-WMIClassObject -Classname "Win32_OSRecoveryConfiguration"
    Invoke-WMIClassWritablePropertySearcher -wmiClass $classObj -DataType String

    .EXAMPLE
    $classesObj = Get-WMIClassObject -All
    Invoke-WMIClassWritablePropertySearcher -wmiClasses $classesObj -DataType DateTime

    .EXAMPLE
    $classesObj = Get-WMIClassObject -All -Namespace SecurityCenter
    Invoke-WMIClassWritablePropertySearcher -wmiClasses $classesObj -DataType Boolean
    
    .NOTES
    Contact information:
    ---------------------
    @b_radmn
    https://github.com/BradyDonovan
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('String', 'UInt8', 'UInt16', 'UInt32', 'UInt64', 'SInt8', 'SInt16', 'SInt32', 'SInt64', 'DateTime', 'Boolean')]
        [string]$DataType,
        [Parameter(ParameterSetName = 'singleWMIClass', Mandatory = $false)] 
        [System.Management.ManagementClass]$wmiClass, # If passing a single WMI class object, use this.
        [Parameter(ParameterSetName = 'multipleWMIClasses', Mandatory = $false)] 
        [System.Object[]]$wmiClasses # If passing multiple WMI class objects, use this.
    )
    process {
        IF ($PSBoundParameters.ContainsKey('wmiClasses')) {
            Write-Verbose "Looking for writable properties of [$DataType] datatype in the following WMI classes:`r`n$($wmiClasses.Name | Out-String)"
            Try {
                $propertyTypeObject = foreach ($wmiClass in $wmiClasses) {
                    foreach ($property in $wmiClass.Properties) {
                        IF (($property.Qualifiers.Name -contains 'write') -and ($property.Type -eq $DataType)) {
                            Write-Verbose "Found writable property [$($property.Name)] in class [$($wmiClass.Name)] of datatype [$($property.Type)]."
                            [PSCustomObject]@{
                                WMIClass     = $wmiClass.Name
                                PropertyName = $property.Name
                                PropertyType = $property.Type
                            }
                        }
                    }
                }
                $propertyTypeObject # Return PSCustomObject containing name of writable property and data type
            }
            Catch {
                throw "Property retrieval failed on class $($wmiClass.Name). Reason:`r`n$_"
            }
            
        }
        IF ($PSBoundParameters.ContainsKey('wmiClass')) {
            Write-Verbose "Looking for writable properties of [$DataType] datatype in the following WMI class:`r`n$($wmiClass.Name | Out-String)"
            Try {
                $propertyTypeObject = foreach ($property in $wmiClass.Properties) {
                    IF (($property.Qualifiers.Name -contains 'write') -and ($property.Type -eq $DataType)) {
                        Write-Verbose "Found writable property [$($property.Name)] in class [$($wmiClass.Name)] of datatype [$($property.Type)]."
                        [PSCustomObject]@{
                            WMIClass     = $wmiClass.Name
                            PropertyName = $property.Name
                            PropertyType = $property.Type
                        }
                    }
                }
                $propertyTypeObject # Return PSCustomObject containing name of writable property and data type
            }
            Catch {
                throw "Property retrieval failed on class $($wmiClass.Name). Reason:`r`n$_"
            }
        }
        IF ($null -eq $propertyTypeObject) {
            Write-Warning -Message "No writable properties of [$DataType] datatype found in WMI class [$($wmiClass.Name)]"
        }
    }
}
function Get-WMIClassObject {
    <#
    .SYNOPSIS
    Retrieves a ManagementClass object.
    
    .DESCRIPTION
    Retrieves a ManagementClass object through Get-WMIObject -List or [wmiclass] type accelerator. Can optionally search all classes or target just one class. Supports all WMI namespaces.
    
    .PARAMETER Classname
    Classname to retrieve a ManagementClass object for. Ex: Win32_OperatingSystem
    
    .PARAMETER All
    Retrieve all ManagementClass objects in a specified namespace (root\cimv2 by default).
    
    .PARAMETER Namespace
    Namespace to use when retrieving ManagementClass objects. Will tab complete through all WMI namespaces.
    
    .EXAMPLE
    $classObj = Get-WMIClassObject -Classname "Win32_OSRecoveryConfiguration"

    .EXAMPLE
    $classesObj = Get-WMIClassObject -All

    .EXAMPLE
    $classesObj = Get-WMIClassObject -All -Namespace SecurityCenter
    
    .NOTES
    Contact information:
    ---------------------
    @b_radmn
    https://github.com/BradyDonovan
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'singleWMIClass', Mandatory = $false, Position = 0)]
        [string]$Classname,
        [Parameter(ParameterSetName = 'allWMIClasses', Mandatory = $false, Position = 1)]
        [switch]$All,
        [Parameter(Position = 2)]
        [ArgumentCompleter( { (Get-WmiObject -Namespace "root" -Class "__Namespace" -Property Name).Name | Sort-Object } )]
        [string]$Namespace = "cimv2" # Default to root\cimv2 as the namespace.
    )
    process {
        # redeclare $Namespace with root\ prefix
        $Namespace = "root\$Namespace"

        IF ($PSBoundParameters.ContainsKey('All')) {
            Try {
                Write-Verbose "Returning class object listing of namespace [$Namespace]."
                $wmiListing = Get-WmiObject -List -Namespace "$Namespace"
                $wmiListing # Return array of System.Management.ManagementClass objects 
                Write-Verbose "Finished class object listing of namespace [$Namespace]."
            }
            Catch {
                throw "Class object retrieval failed. Reason:`r`n$_"
            }
        }
        IF ($PSBoundParameters.ContainsKey('Classname')) {
            Try { 
                Write-Verbose "Returning single class object of [$Classname] in namespace [$Namespace]."
                [wmiclass]"$Namespace`:$ClassName" # Return single instance of System.Management.ManagementClass
                Write-Verbose "Returned single class object of [$Classname] in namespace [$Namespace]."
            }
            Catch {
                throw "Class object retrieval failed. Reason`r`n$_"
            }
        }
    }
}
