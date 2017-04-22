. $PSScriptRoot\private\sqlcmd2.ps1

function new-RWCredential{

<#

            .SYNOPSIS

            Creates Crdential Xml file for use in connecting to RenWeb Database.

 

            .DESCRIPTION

            Creates the clixml file that can be used within the RWODBC module to connect to RenWeb.

 

            .EXAMPLE

            new-RWCredential "C:\scripts\resources\"

            
            Prompts for RenWeb ODBC username and password, and creates RWCred.xml in the directory C:\scripts\resources 

 

            .NOTES

            

 

            .LINK

            

 

    #>


    [CmdletBinding()]

    param(
            
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$False)]
        [STRING]$path

        
    )   


get-credential | Export-Clixml -Path "$path\RWCred.xml"

}


function get-RenwebData{

    <#

            .SYNOPSIS

            Queries the RenWeb database.

 

            .DESCRIPTION

            Connects to the RenWeb ODBC purchased access, and runs queries to gather data.  NOTE: RenWeb ODBC access is read-only - craft queries with this in mind!
             

            .EXAMPLE

            Get-RenWebData -Server "foo.server.com" -DataBaseName "BAR" -CredentialPath "C:\resources\" -Query "SELECT my_db.dbo.Person.FirstName AS fname FROM dbo.Person INNER JOIN dbo.Person_Student ON dbo.Person.PersonID=dbo.Person_Student.StudentID WHERE dbo.Person_Student.GradeLevel='12'"

 

            Runs the query to list the first names of every 12th grade student

 

            .NOTES

            

 

            .LINK

            

 

    #>


    [CmdletBinding()]

    param(
            
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$False)]
        [STRING]$Server,

        [parameter(Mandatory=$true, Position=1, ValueFromPipeline=$False)]
        [STRING]$CredentialPath,

        [parameter(Mandatory=$true, Position=2, ValueFromPipeline=$False)]
        [STRING]$DataBaseName,

        [parameter(Mandatory=$true, Position=3, ValueFromPipeline=$False)]
        [STRING]$Query
    )   

    Begin{
     
     $credpath = "$CredentialPath" + "RWCred.xml"
     $mycreds = import-clixml "$credpath"   

    }

    Process {

        
        Invoke-Sqlcmd2 -ServerInstance $Server -Database $DatabaseName -Credential $mycreds -Query $Query

    }

    end{}
}

function get-RenwebStudent{


<#

            .SYNOPSIS

            Gets student info from the RenWeb Database by grade.

 

            .DESCRIPTION

            Connects to the RenWeb ODBC purchased access, and queries the databse to get student information based on grade level.  NOTE: RenWeb ODBC access is read-only - craft queries with this in mind!
            

            .EXAMPLE


            Get-RenWebstudents -Server "foo.server.com" -DataBaseName "BAR" -CredentialPath "C:\resources\" -Grades "07"

 
            Gets the first, middle, and last name, email and address of each student in 7th Grade.


            .EXAMPLE


            Get-RenWebstudents -Server "foo.server.com" -DataBaseName "BAR" -CredentialPath "C:\resources\" -Grades "07"

            Gets the first, middle, and last name, email and address of each student in 7th or 10th Grade.


            .NOTES

            RenWeb uses 2 digit grade-level indicators which are alphanumeric.  So for example, 1st grade should be entered as 01.

            
    #>


    [CmdletBinding()]

    param(
            
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$False)]
        [STRING]$Server,

        [parameter(Mandatory=$true, Position=1, ValueFromPipeline=$False)]
        [STRING]$CredentialPath,

        [parameter(Mandatory=$true, Position=2, ValueFromPipeline=$False)]
        [STRING]$DataBaseName,

        [parameter(Mandatory=$true, Position=3, ValueFromPipeline=$False)]
        [STRING[]]$Grades
    )   

    Begin{
        
             
        $credpath = "$CredentialPath" + "RWCred.xml"
     $mycreds = import-clixml "$credpath" 

        $InitGrade = $Grades[0]

        If($Grades.Length -gt 1){
            $Grades = $Grades[1..($Grades.Length-1)]
        }

        $Query = "SELECT dbo.Person.FirstName AS firstname,
                       dbo.Person.MiddleName AS middlename,
	                   dbo.Person.LastName AS lastname,
	                   dbo.Person.Email AS email,
	                   dbo.Address.Address1 AS address1,
	                   dbo.Address.Address2 AS address2,
	                   dbo.Address.City AS city,
	                   dbo.Address.State AS state,
	                   dbo.Address.Zip AS zip
                FROM dbo.Person
	                INNER JOIN dbo.Person_student
			                ON dbo.Person.PersonID = dbo.Person_Student.StudentID
	                INNER JOIN dbo.Address
			                ON dbo.Person.AddressID = dbo.Address.AddressID
                WHERE dbo.Person_Student.GradeLevel = '$InitGrade'"

        ForEach ($Grade in $Grades){
            $Query = $Query + " OR dbo.Person_Student.GradeLevel = '$Grade'"
        }

        

    }

    Process {

        
        Invoke-Sqlcmd2 -ServerInstance $Server -Database $DatabaseName -Credential $mycreds -Query $Query

    }

    end{}
}









Export-ModuleMember -Function get-RenwebData
Export-ModuleMember -Function get-RenwebStudent
Export-ModuleMember -Function new-RWCredential