gpg --armor --export > gpg_pub.asc
gpg --armor --export-secret-keys > gpg_priv.asc
gpg --export-ownertrust > gpg_trust.asc
tar -cvzf "gpg_bkup_$(date +%F).tar.gz" gpg_pub.asc gpg_priv.asc gpg_trust.asc && rm gpg_pub.asc gpg_priv.asc gpg_trust.asc
