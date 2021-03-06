function New-Object
{
    [CmdletBinding(DefaultParameterSetName='Net')]
    param(
        [Parameter(ParameterSetName='Net', Mandatory=$true, Position=0)]
        [string]
        ${TypeName},

        [Parameter(ParameterSetName='Com', Mandatory=$true, Position=0)]
        [string]
        ${ComObject},

        [Parameter(ParameterSetName='Net', Position=1)]
        [Alias('Args')]
        [System.Object[]]
        ${ArgumentList},

        [Parameter(ParameterSetName='Com')]
        [switch]
        ${Strict},

        [System.Collections.IDictionary]
        ${Property})

    begin
    {
        Set-StrictMode -Version 2

        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $ClsidPresent = $true
            $Guid = [Guid]::NewGuid()

            try
            {
                $Guid = [Guid] $PSBoundParameters['ComObject']
            }
            catch
            {
                $ClsidPresent = $false

                $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('New-Object', [System.Management.Automation.CommandTypes]::Cmdlet)
                $scriptCmd = {& $wrappedCmd @PSBoundParameters }
                $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
                $steppablePipeline.Begin($PSCmdlet)
            }
        } catch {
            throw
        }
    }

    process
    {
        if ($ClsidPresent)
        {
            [Activator]::CreateInstance([Type]::GetTypeFromCLSID($Guid), $Property)
        }
        else
        {
            try {
                $steppablePipeline.Process($_)
            } catch {
                throw
            }
        }
    }

    end
    {
        if (!$ClsidPresent)
        {
            try {
                $steppablePipeline.End()
            } catch {
                throw
            }
        }
    }
    <#

    .ForwardHelpTargetName New-Object
    .ForwardHelpCategory Cmdlet

    #>
}
