APPLFOWY_PATH=appflowy
mkdir $APPLFOWY_PATH

update_cache() {
    sudo apt update
    sudo apt upgrade -y
    sudo apt install git -y
}

install_docker() {
    sudo apt install -y docker.io
    sudo systemctl restart docker
    sudo groupadd docker
    sudo usermod -aG docker $USER || return 0
}

uninstall_docker() {
    sudo apt autoremove -y docker.io || return 0
}

install_compose() {
    curl -sSL https://gist.githubusercontent.com/kamuridesu/d8be27b388f54c221a2889e7a94943c3/raw/a46a54047488d7f571459784f4ea5c707f050c68/docker-compose.sh | sh -
}

uninstall_compose() {
    rm $DOCKER_CONFIG/cli-plugins/docker-compose
}

deploy_applflowy_cloud() {
    git clone --depth 1 --branch 0.4.10 https://github.com/AppFlowy-IO/AppFlowy-Cloud.git $APPLFOWY_PATH
    cd $APPLFOWY_PATH
    cp deploy.env .env
    docker compose up -d
    cd -
}

remove_applflowy_cloud() {
    cd $APPLFOWY_PATH
    docker compose down
    cd -
    rm -rf $APPLFOWY_PATH
    docker rmi -f $(docker images -q)
}

cleanup() {
    remove_applflowy_cloud
    uninstall_compose
    uninstall_docker
}

setup() {
    update_cache
    install_docker
    install_compose
    deploy_applflowy_cloud
}

if [[ "$1" == "clean" ]]; then
    cleanup
else
    setup
fi
