#!/usr/bin/awk
{
FS=":"
}
{
if ($3 > 500)
print $3
}
