## How to Upgrade Swiftlint

### Step 1: Find the hash of the new swiftlint binary
Go on the Swiftlint repo, download the latest archive and unzip it
On macos: execute a md5 against the `swiftint` binary
On linux: execute a md5sum against the `swiftint` binary
Save the hash

### Step 1: Clone this repository

### Step 2: Execute the rakefile
To fetch the latest hash version, you need to execute the rakefile in this folder

```bash
bundle install && rake

```

The hash is printed in the terminal (`-dh` value)

### Step 3: Open the PR
If you don't have errors on step 3, then you can open a PR by editing the file
`/lib/version.rb` and changing :
- SWIFTLINT_VERSION=${target_swiftlint_version}
- SWIFTLINT_HASH=${md5_hash}

Thank you for your contributions.
