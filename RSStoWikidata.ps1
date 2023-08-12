# Get Atom Feed
$Response = Invoke-WebRequest -Uri "https://feeds.megaphone.fm/LAV7402407500" -UseBasicParsing -ContentType "application/xml"
If ($Response.StatusCode -ne "200") {
    # Feed failed to respond.
    Write-Host "Message: $($Response.StatusCode) $($Response.StatusDescription)"
}

$FeedXml = [xml]$Response.Content
$Entries = @()
$Now = Get-Date

# Exract recent entries (currently set for updated within the last 24 hours)
ForEach ($Entry in $FeedXml.feed.entry) {

    $Entry 
}


$QID="Q79675897"
$chfeed = [xml](Invoke-WebRequest "https://feeds.megaphone.fm/LAV7402407500")
$chfeed.rss.channel.item | Select-Object pubDate
$countitems = 0
[datetime] $oldestdate="1972-08-14"
[datetime] $newestdate="1972-08-14"

ForEach ($Entry in $chfeed.rss.channel.item) {

    [datetime] $date=[datetime] $Entry.pubDate
    if ($oldestdate="1972-08-14") {$oldestdate=$date}
    #if ($newestdate="1972-08-14") {$newestdate=$date}
    if ($date -lt $oldestdate) {$oldestdate=$date}
    if ($date -gt $newestdate) {$newestdate=$date}
    $countitems += 1
}

$title=$chfeed.rss.channel.title.replace("|","%7C")
$date=Get-Date
"QID,P1476,P580,P1113,S585"
$QID+","""+$title+""","""+$oldestdate+""","""+$countitems+""""+$date+""""

#$QID+"|P1476|"+$title+"|P580|"+$oldestdate+"|P1113|"+$countitems+"|S585|"+$date

#$countitems
#$countitems
#$oldestdate
#$newestdate

#$chfeed.rss.channel.subtitle