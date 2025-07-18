# vm-util

## Virtual Machine Setup

1.  `vm-vm-create NAME ZONE TYPE`, wait 5 mins
2.  `vm-vm-scp-setup-scripts NAME ZONE`
3.  `vm-vm-ssh NAME ZONE`
4.  `./vm-keygen`
5.  `./vm-vm-setup`
6.  Configure commit signing

    ```shell
    gpg --full-generate-key
    echo 'export GPG_TTY=$(tty)' >> ~/.bashrc

    gpg --list-secret-keys --keyid-format LONG <your_email>
    # Look for a line starting with `sec` and copy the GPG private key ID (the
    # 16-character hexadecimal string after the slash)
    git config --global user.signingkey <YOUR_GPG_KEY_ID>
    git config --global commit.gpgsign true

    gpg --armor --export <YOUR_GPG_KEY_ID>
    # Add the public key at https://github.com/settings/keys
	```
7.  Log in to Docker:

    ```shell
	# Create new token at https://app.docker.com/accounts/<username>/settings/personal-access-tokens/create
	docker login -u <username>
    ```

8.  Log in to Quay.io

    ```shell
	# Create an encrypted password at https://quay.io/user/<username>/?tab=settings
    docker login -u <username> -p '<password>' quay.io
    ```

9.  Set `GITHUB_TOKEN`:

    ```shell
	# Generate the token at https://github.com/settings/tokens
	export GITHUB_TOKEN=
    ```
