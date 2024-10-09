## How to Upgrade Swiftlint

### Step 1: Find the hash of the new swiftlint binary

Go on the [Swiftlint repo's releases page](https://github.com/realm/SwiftLint/releases), go to the "Assets" section, and download the `portable_swiftlint.zip` file. Then open a terminal and get the md5 hash:


```sh
# macos 
md5 -q  portable_swiftlint.zip

# linux
md5sum portable_swiftlint.
```

Copy the hash.

<details><summary>Why is the md5 has important?</summary>

Swiftlint is often used in CI environments, which have access to sensitive data. An attacker attempt a [MitM attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) to replace the version of Swiftlint installed by this Danger plugin. By checking the hash of the Swiftlint version, we seek to mitigate this attack vector. [See #170 for more](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/170).

</details>

### Step 2: Update the Hash

Edit [`/lib/version.rb`](https://github.com/ashfurrow/danger-ruby-swiftlint/blob/master/lib/version.rb) and change the following values:

- `SWIFTLINT_VERSION` to the version of SwiftLint you're updating too.
- `SWIFTLINT_HASH` to the hash value from Step 1.

Then open a PR. Thank you for your contribution!
