# Notes on Making VictoriaMetrics Releases

## How to Set up a Victual Machine

1.  Create a virtual machine and SSH to it
2.  Install software:

    ```shell
    sudo apt install tmux emacs-nox git make docker

    wget https://go.dev/dl/go1.24.4.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.24.4.linux-amd64.tar.gz
    ```

3.  Configure software

    ```shell
    cat <<EOF >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin

    EOF
    ```

4.  Generate a new SSH key and add it to GitHub ([instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent))

    ```shell
    ssh-keygen -t ed25519 -C "your_email@example.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    cat ~/.ssh/id_ed25519.pub
    ```

5.  Pull `vm-util` repo:

    ```shell
    git clone git@github.com:rtm0/vm-util.git
    ```

5.  Set up VictoriaMetrics local repo:

    ```shell
    mkdir -p ~/VictoriaMetrics/01
    cd ~/VictoriaMetrics/01
    ~/vm-util/releases/git-setup-branches.sh
    ```
