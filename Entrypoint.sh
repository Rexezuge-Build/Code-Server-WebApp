if [ "$SSH_PUBLIC_KEY" != 0 ]
then
cat > /root/.ssh/authorized_keys << EOF
${SSH_PUBLIC_KEY}
EOF
fi

service ssh start
code-server
