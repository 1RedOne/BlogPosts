Follow these steps to follow along with the blog post 'MVC Excursions' on FoxDeploy.

### Setup SQL

Use SQL Express or Standard (or Datacenter if you're made of cash) and create a new DB called `MVCDemo`.  Then run this script to create our table and populate it with data.

````SQL
USE MVCDemo
GO
/****** Object:  Table [dbo].[books]    Script Date: 10/10/2018 10:43:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[books](
	[id] [smallint] NOT NULL,
	[title] [varchar](33) NULL,
	[author] [varchar](14) NULL,
	[format] [varchar](10) NULL,
	[price] [real] NULL
) ON [PRIMARY]

GO
INSERT [dbo].[books] ([id], [title], [author], [format], [price]) VALUES (1, N'"To Kill a Foxingbird"', N' "Sir Yipalot"', N' paperback', 9.99)
GO
INSERT [dbo].[books] ([id], [title], [author], [format], [price]) VALUES (2, N'"The Adventures of Fox and Goose"', N'"Sir Yipalot"', N'paperback', 10.99)
GO
INSERT [dbo].[books] ([id], [title], [author], [format], [price]) VALUES (3, N'"The Return of Fox and Goose"', N'"Sir Yipalot"', N'paperback', 19.99)
GO
INSERT [dbo].[books] ([id], [title], [author], [format], [price]) VALUES (4, N'"More Fun with Fox and Goose"', N'"Sir Yipalot"', N'paperback', 12.99)
GO
INSERT [dbo].[books] ([id], [title], [author], [format], [price]) VALUES (5, N'"Fox and Goose on Holiday"', N'"Sir Yipalot"', N'paperback', 11.99)
GO
INSERT [dbo].[books] ([id], [title], [author], [format], [price]) VALUES (6, N'"The Return of Fox and Goose"', N'"Sir Yipalot"', N'hardback', 19.99)
GO
INSERT [dbo].[books] ([id], [title], [author], [format], [price]) VALUES (7, N'"The Adventures of Fox and Goose"', N'"Sir Yipalot"', N'hardback', 18.99)
GO
INSERT [dbo].[books] ([id], [title], [author], [format], [price]) VALUES (8, N'"My Friend is a Fox"', N'"A. Parrot"', N'paperback', 14.99)
GO

````

### Connecting the solution file to your database

Fire up Visual Studio and open up the SLN file attached.

Next, right-click **Models** and choose **Add-->New ADO.Net Entity Data Model**.

[!]('img/Add Ado EF.png')
Name this Model **MVCDemo**.

Select **EF Designer From Database**

Click **New Connection**.  

If you're using SQLExpress, input these values:

Server Name : **localhost\SQLExpress**

Select or enter a database name: **MVCDemo**

Click **Test Connection** and if it works, then click **OK**, and **Next**.

Select **EF Framework 6.0**

Finally, click expand down to **Tables-->DBO->books** and click **Finish**.

Now, click Build and then hit F5!  Now, try to click **Books** to see the Entity Framework in action!  You're now ready to tag along for the rest of the series.