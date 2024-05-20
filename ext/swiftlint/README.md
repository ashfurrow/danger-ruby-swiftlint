## How to Upgrade Swiftlint

### Step 1: Find the hash of the new swiftlint binary

Go on the Swiftlint repo, download the latest archive and unzip it
On macos: execute a md5 against the `swiftint` binary
On linux: execute a md5sum against the `swiftint` binary
Save the hash

<details><summary>Why is the md5 has important?</summary>

Swiftlint is often used in CI environments, which have access to sensitive data. An attacker attempt a [MitM attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) to replace the version of Swiftlint installed by this Danger plugin. By checking the hash of the Swiftlint version, we seek to mitigate this attack vector. [See #170 for more](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/170).

</details>

### Step 2: Fork and clone this repository

### Step 3: Execute the rakefile

To fetch the latest hash version, you need to execute the rakefile in this folder

```bash
bundle install && rake
```

The hash is printed in the terminal (`-dh` value)

### Step 3: Open the PR

If you don't have errors on step 3, then you can open a PR by editing the file
`/lib/version.rb` and changing:

- SWIFTLINT_VERSION=${target_swiftlint_version}
- SWIFTLINT_HASH=${md5_hash}

Thank you for your contributions.
