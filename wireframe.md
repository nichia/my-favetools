## Models
### User
#### Attributes
-	name
-	email
-	password_digest
#### Associations
-	has many folders
-	has many tools, through folders
-	has many categories through folders

### Folders
#### Attributes
-	name
-	description
-	privacy
-	user id
-	category id
#### Associations
-	belongs to user
-	belongs to category
-	has many items

### Categories
#### Attributes
-	name
#### Associations
-	has many folders
-	has many users through folders

### Items
#### Attributes
-	name
-	description
-	url link
-	rating
-	folder id
#### Associations
-	belongs to folder
