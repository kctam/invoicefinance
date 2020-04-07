echo "==================="
echo "Teardown everything"
echo "==================="
cd ./network
docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml down -v
docker rm $(docker ps -aq)
docker rmi $(docker images dev-* -q)
echo
echo "================="
echo "Teardown complete"
echo "================="
