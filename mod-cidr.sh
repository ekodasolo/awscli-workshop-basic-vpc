# Find cidr notation in runbooks
grep "=\"10\.0\.0" *-Runbook{,-[0-9]}.md

# Substitute cidr for each file
sed -e 's/=\"10\.0\.0/=\"10.0.1/g' 0101-CreateVPC-Runbook.md 
sed -e 's/=\"10\.0\.0/=\"10.0.1/g' 0504-CreateRoute-Runbook-1.md 
sed -e -i 's/=\"10\.0\.0/=\"10.0.1/g' 0101-CreateVPC-Runbook.md 
sed -i -e 's/=\"10\.0\.0/=\"10.0.1/g' 0101-CreateVPC-Runbook.md 

# Substitute cidr all at once
sed -i -e 's/=\"10\.0\.0/=\"10.0.1/g' *-Runbook{,-[0-9]}.md
