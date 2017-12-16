Function Send-RedditMessage {param(
$AccessToken,
$Recipient,
$subject,
$post,
$userAgent = 'AzureFunction-SubredditBot:0.0.2 (by /u/1RedOne)'
)

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("User-Agent", 'AzureFunction-SubredditBot:0.0.2 (by /u/1RedOne)')
$headers.Add("Authorization", "bearer $AccessToken")

$bodyMarkdown = "
Hi Stephen,

A new post was submitted on [/r/FoxDeploy](http://www.reddit.com/r/FoxDeploy), you should check it out.


Post Title: $($post.data.title)

Post link here: [Click here for the link]($($post.data.url))

----------


This alert was generated at $time."

$body = @{
    api_type = 'json'
    to = $Recipient #@'1RedOne'
    subject = $subject
    text=$bodyMarkdown
}


$Request = Invoke-RestMethod -Headers $headers -Uri https://oauth.reddit.com/api/compose -Method Post -Body $body -ContentType 'application/x-www-form-urlencoded'

If ($Request.json.errors.Count -eq 0){
    Write-Host -ForegroundColor Green 'Message sent'
    }
    else{
    Write-Warning 'Error'
    }

}