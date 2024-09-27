We need to decide which secrets provider we will be using for our setup, main requirement is for it to be supported by External Secrets Operator.


### Self-hosted and Free Options:
1. **Bitwarden Secrets Manager**
   - **Free & Self-hosted**: Bitwarden can be self-hosted for free, making it a good option for homelab use.
   - **Compatibility**: ESO supports Bitwarden for secret management.

2. **HashiCorp Vault**
   - **Free & Self-hosted**: The open-source version of HashiCorp Vault can be self-hosted for free and is commonly used for homelab and enterprise environments.
   - **Compatibility**: Fully supported by ESO.

3. **CyberArk Conjur**
   - **Free & Self-hosted**: Conjur has an open-source, self-hosted version that you can deploy in your homelab.
   - **Compatibility**: Supported by ESO.

4. **Kubernetes Secrets**
   - **Free & Built-in**: Kubernetes secrets are natively free to use in any Kubernetes cluster.
   - **Compatibility**: Fully supported by ESO.

5. **Passbolt**
   - **Free & Self-hosted**: Passbolt offers a free, self-hosted version designed for teams and homelab use.
   - **Compatibility**: ESO supports Passbolt integration.

### Free or Free Tier (Cloud-hosted):
1. **AWS Secrets Manager**
   - **Free Tier**: AWS offers a limited free tier, but you would eventually have to pay for ongoing use.
   - **Compatibility**: Supported by ESO.

2. **AWS Parameter Store**
   - **Free Tier**: AWS Parameter Store has a free tier with limits; beyond that, it requires payment.
   - **Compatibility**: Fully supported.

3. **Azure Key Vault**
   - **Free Tier**: Azure Key Vault offers a limited free tier, but requires payment beyond that.
   - **Compatibility**: Supported by ESO.

4. **Google Cloud Secret Manager**
   - **Free Tier**: Google Cloud offers a free tier with limitations, with pricing for extensive use.
   - **Compatibility**: Supported by ESO.

5. **GitLab Variables**
   - **Free Tier**: GitLab offers free private repositories and variables can be used without a paid subscription.
   - **Compatibility**: Supported by ESO.

6. **Infisical**
   - **Free Tier**: Infisical offers a free tier for teams, which could be suitable for small-scale homelab use.
   - **Compatibility**: Supported by ESO.

### Paid or Limited Options:
1. **1Password Secrets Automation**, **Delinea (Secret Server)**, **Keeper Security**, **Doppler**, **BeyondTrust**, **Device42**, **IBM Secrets Manager**, **Oracle Vault**, **Akeyless**, **senhasegura DSM**, **Pulumi ESC**, **Fortanix**, **Password Depot**, and **Alibaba Cloud** generally require paid subscriptions or enterprise licenses for ongoing use.

### Conclusion:
For a homelab setup, **Bitwarden**, **HashiCorp Vault**, **Kubernetes Secrets**, and **Passbolt** are your best free or self-hosted options. If you're looking for cloud-based services with a free tier, **AWS Secrets Manager**, **Azure Key Vault**, and **Google Cloud Secret Manager** are potential options, though they come with limitations on the free tier usage.
