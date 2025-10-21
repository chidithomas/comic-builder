Comic Builder Smart Contract

🧩 Overview

The Comic Builder contract enables creators and community members to collaboratively build, own, and curate comics on-chain.
Each story panel is minted as an NFT, and users can assemble multiple panels into a comic, which the community can then upvote.
This contract promotes decentralized storytelling, NFT-based art collaboration, and community-driven curation.

⚙️ Core Functionalities
🖼️ 1. Mint Story Panels (NFTs)

Creators can mint unique comic panels represented as NFTs.
Each panel includes metadata like title, description, image URI, and timestamp.

Function: mint-panel

Parameters:

title — (string-ascii 50): The title of the panel.

image-uri — (string-ascii 256): Link to the image or artwork.

description — (string-ascii 500): Description of the panel.

Returns: The panel-id of the newly minted panel.

🔁 2. Transfer Panel Ownership

Allows the current owner of a panel NFT to transfer it to another user.

Function: transfer-panel

Parameters:

panel-id — The ID of the panel to transfer.

recipient — The new owner’s principal.

Access: Only the current owner can transfer.

📚 3. Assemble Panels into Comics

Users can assemble up to 20 panels into a complete comic.

Function: create-comic

Parameters:

title — (string-ascii 100): Title of the comic.

panel-ids — (list 20 uint): List of panel IDs to include.

Validations:

A comic must include at least one panel and no more than 20.

Returns: The comic-id of the newly created comic.

👍 4. Upvote Comics

Community members can upvote comics to show appreciation and surface popular works.

Function: upvote-comic

Parameters:

comic-id — The ID of the comic to upvote.

Restrictions:

Each user can only upvote a comic once.

👎 5. Remove Upvote

Users can remove a previous upvote if they change their opinion.

Function: remove-upvote

Parameters:

comic-id — The ID of the comic.

Restrictions:

Can only be called by users who have already upvoted that comic.

🧠 Read-Only Queries
Function	Description
get-panel	Fetches details of a panel by ID.
get-panel-owner	Returns the current owner of a panel.
get-comic	Retrieves full comic metadata by ID.
get-last-panel-id	Returns the latest minted panel ID.
get-last-comic-id	Returns the latest created comic ID.
has-voted	Checks if a user has already upvoted a specific comic.
🪙 Data Structures
Panels

Stores metadata for each story panel NFT.

{ creator: principal, title: (string-ascii 50), image-uri: (string-ascii 256), description: (string-ascii 500), created-at: uint }

Comics

Represents assembled comics containing multiple panels.

{ creator: principal, title: (string-ascii 100), panel-ids: (list 20 uint), created-at: uint, upvotes: uint }

Votes

Tracks user upvotes per comic.

{ comic-id: uint, voter: principal } => bool

🔒 Access Control & Errors
Error Code	Meaning
err-owner-only (u100)	Action restricted to contract owner.
err-not-panel-owner (u101)	Caller is not the owner of the specified panel.
err-panel-not-found (u102)	Panel does not exist.
err-comic-not-found (u103)	Comic does not exist.
err-invalid-panel-count (u104)	Invalid number of panels when creating a comic.
err-already-voted (u105)	User has already voted for this comic.
🚀 Example Workflow

Alice mints three panels using mint-panel.

Alice assembles them into a comic using create-comic.

Bob views the comic and upvotes it using upvote-comic.

Charlie transfers his panel to Diana using transfer-panel.

Bob later removes his vote using remove-upvote.

🧾 Future Enhancements (Ideas)

Add comments or feedback system for comics.

Enable panel royalties for creators.

Introduce comic collaboration (multi-user ownership).

Implement ranking algorithm for trending comics.

🧑‍💻 Contract Summary
Feature	Supported
NFT Minting	✅
Ownership Transfer	✅
Comic Assembly	✅
Upvotes	✅
Vote Revocation	✅
Read-Only Queries	✅

📄 License

This contract is open-source and can be used for educational or creative blockchain storytelling projects under the MIT License.