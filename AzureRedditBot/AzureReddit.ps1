#region startup 
#Boot up, load settingscheck for a post that needs to alert
set-location D:\home\site\wwwroot\CheckForNewPosts\
$settings = get-content .\RedditSettings.json -Raw | ConvertFrom-Json
$time = "{0:yyyy-MM-dd HH:mm:ss}" -f (get-date)
. .\Send-RedditMessage.ps1
. .\Refresh-RedditToken.ps1

#load DB file
$Processed = Import-CSV .\processed.txt

#process posts
$posts = Invoke-RestMethod https://www.reddit.com/r/FoxDeploy/new.json

ForEach ($post in $posts.data.children){
    if ($Processed.PostName -notcontains $post.data.title){
    #We need to send a message
    Write-output "We haven't seen $($post.data.title) before...breaking loop"
    break
    }

}

#retrieve token
$token = Refresh-RedditToken -settings $settings

#send message
Write-output "Sent message"
Send-RedditMessage -AccessToken $token.access_token -Recipient 1RedOne -subject 'New Post Alert!' -post $post

#log message
Add-Content -Value "$($post.data.title),$time" -path D:\home\site\wwwroot\CheckForNewPosts\processed.txt
