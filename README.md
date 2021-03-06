## Synopsis

PSRWODBC is a powershell module that assits in queries to the ODBC provided by RenWeb

## Code Example

```
new-RWCred "C:\resources\"
```

Prompts for RW ODBC username and password (supplied by Renweb) and creates the xml file for later logins.  This command must be run once for on each computer the module will be used on.

```
get-RenwebStudent -Server foo -DataBaseName bar -CredentialPath "c:\resources\" -Grades "07"
```
 
Gets the first, middle, and last name, email and address of each student in 7th Grade.

```
get-RenwebStudent -Server foo -DataBaseName bar -CredentialPath "c:\resources\" -Query "SELECT my_db.dbo.Person.FirstName AS fname
FROM dbo.Person 
INNER JOIN dbo.Person_Student 
ON dbo.Person.PersonID=dbo.Person_Student.StudentID 
WHERE dbo.Person_Student.GradeLevel='12'" 
```

Runs the query to list the first names of every 12th grade student

## Motivation

RenWeb allows schools to purchase access through an ODBC to the database on which their data sits.  Using this with Powershell, schools can automate the process of gathering data for various purposes.  One popular reason to do this is for account creation in Active Directory, Google Apps, or O365

## License

MIT