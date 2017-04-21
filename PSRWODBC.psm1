function global:get-RenwebData{

    <#

            .SYNOPSIS

            Queries the RenWeb database.

 

            .DESCRIPTION

            Connects to the RenWeb ODBC purchased access, and runs queries to gather data.  NOTE: RenWeb ODBC access is read-only - craft queries with this in mind!
            Requires:
                 Microsoft® System CLR Types for Microsoft SQL Server® 2016 (SQLSysClrTypes.msi)
                 Microsoft® SQL Server® 2016 Shared Management Objects (SharedManagementObjects.msi)
                 Microsoft® Windows PowerShell Extensions for Microsoft SQL Server® 2016 (PowerShellTools.msi)

 

            .EXAMPLE

            Get-RenWebData foo.server.name my_database username password "SELECT my_db.dbo.Person.FirstName AS fname FROM dbo.Person INNER JOIN dbo.Person_Student ON dbo.Person.PersonID=dbo.Person_Student.StudentID WHERE dbo.Person_Student.GradeLevel='12'"

 

            Runs the query to list the first names of every 12th grade student

 

            .NOTES

            

 

            .LINK

            

 

    #>


    [CmdletBinding()]

    param(
            
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$False)]
        [STRING]$Server,

        [parameter(Mandatory=$true, Position=1, ValueFromPipeline=$False)]
        [STRING]$UserName,

        [parameter(Mandatory=$true, Position=2, ValueFromPipeline=$False)]
        [STRING]$Password,

        [parameter(Mandatory=$true, Position=3, ValueFromPipeline=$False)]
        [STRING]$DataBaseName,

        [parameter(Mandatory=$true, Position=4, ValueFromPipeline=$True)]
        [STRING]$Query
    )   

    Begin{

        import-module sqlps

    }

    Process {

        
        Invoke-Sqlcmd -ServerInstance $Server -Database $DatabaseName -Username $UserName -Password $Password -Query $Query

    }

    end{}
}

function global:get-RenwebStudent{


<#

            .SYNOPSIS

            Gets student info from the RenWeb Database by grade.

 

            .DESCRIPTION

            Connects to the RenWeb ODBC purchased access, and queries the databse to get student information based on grade level.  NOTE: RenWeb ODBC access is read-only - craft queries with this in mind!
            Requires:
                 Microsoft® System CLR Types for Microsoft SQL Server® 2016 (SQLSysClrTypes.msi)
                 Microsoft® SQL Server® 2016 Shared Management Objects (SharedManagementObjects.msi)
                 Microsoft® Windows PowerShell Extensions for Microsoft SQL Server® 2016 (PowerShellTools.msi)

 

            .EXAMPLE


            Get-RenWebstudents foo.server.name my_database username password 07

 
            Gets the first, middle, and last name, email and address of each student in 7th Grade.


            .EXAMPLE


            Get-RenWebstudents foo.server.name my_database username password "07","10"

            Gets the first, middle, and last name, email and address of each student in 7th or 10th Grade.


            .NOTES

            RenWeb uses 2 digit grade-level indicators which are alphanumeric.  So for example, 1st grade should be entered as 01.

            
    #>


    [CmdletBinding()]

    param(
            
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$False)]
        [STRING]$Server,

        [parameter(Mandatory=$true, Position=1, ValueFromPipeline=$False)]
        [STRING]$UserName,

        [parameter(Mandatory=$true, Position=2, ValueFromPipeline=$False)]
        [STRING]$Password,

        [parameter(Mandatory=$true, Position=3, ValueFromPipeline=$False)]
        [STRING]$DataBaseName,

        [parameter(Mandatory=$true, Position=4, ValueFromPipeline=$False)]
        [STRING[]]$Grades
    )   

    Begin{
        
             
        import-module sqlps

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

        
        Invoke-Sqlcmd -ServerInstance $Server -Database $DataBaseName -Username $UserName -Password $Password -Query $Query

    }

    end{}
}









Export-ModuleMember -Function get-RenwebData
Export-ModuleMember -Function get-RenwebStudents