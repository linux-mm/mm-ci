# GitHub Actions Runner Setup

1. To create a new instance, run `./create_instance.sh $n` where `n` is the ID
   for the new runner.

   This idiocy is necessary because Terraform has been made impractical by
   Broccoli.

1. Search internally for "GCE SSH" and go through the stupid checklist to get
   SSH access. This is garbage, it breaks all the time, you just have to take a
   deep breath and repeat the checklist. I think most commonly the `gcloud
   compute os-login ssh-keys add` command is the particular thing that fixes it,
   but not always.

1. Add any new instances to `inventory.yaml` by copy pasting the boilerplate
   from existing instances.

1. Modify the `ansible_user` in `inventory.yaml` to correspond to your OSLogin
   user (`$USER_google_com`).

1. Generate a Personal Access Token (PAT). Go to the "Tokens (classic)"
   [page](https://github.com/settings/tokens) in Github's "developer settings" and
   generate a token with the full `repo` and `admin:org` scopes.

   Write it to `secrets.yml` in the form `github_access_token: <token>`

1.  One-time Ansible setup:

    ```bash
    ansible-galaxy role install -r requirements.yml
    ```

1.  Apply the playbook to all the hosts:

    ```bash
    ansible-playbook -i inventory.yaml playbook.yml
    ```
