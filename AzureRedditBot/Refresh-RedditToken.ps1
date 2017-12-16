Function Refresh-RedditToken{param($settings)


$body = @{
    client_id = $settings.client_id
    grant_type = 'refresh_token'
    refresh_token = $settings.refresh_token
    redirect_uri = $settings.redirect_uri 
    duration= $settings.duration 
    scope=  $settings.scope # 'identity','history','mysubreddits','read','report','privatemessages','save','submit'

}
$tempPW = ConvertTo-SecureString $settings.secret -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($settings.client_id, $tempPW)

Invoke-RestMethod https://www.reddit.com/api/v1/access_token -Body $body -Method Post  -Credential $credential #-ContentType "application/x-www-form-urlencoded"


}