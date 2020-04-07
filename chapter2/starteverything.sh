cd ./network

# bring up containers
echo "==================="
echo "bring up containers"
echo "==================="
docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml up -d

# bring up invoice-channel and joining all four peers
echo
echo "================================"
echo "bring up and join invoice-channel"
echo "================================"
echo "--create channel genesis block--"
docker exec cli peer channel create -o orderer.example.com:7050 -c invoice-channel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
sleep 10
echo "--join peer0.alpha.example.com to invoice-channel--"
docker exec cli peer channel join -b invoice-channel.block
echo "--join peer1.alpha.example.com to invoice-channel--"
docker exec -e CORE_PEER_ADDRESS=peer1.alpha.example.com:8051 -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/alpha.example.com/peers/peer1.alpha.example.com/tls/ca.crt cli peer channel join -b invoice-channel.block
echo "--join peer0.beta.example.com to invoice-channel--"
docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/beta.example.com/users/Admin@beta.example.com/msp -e CORE_PEER_ADDRESS=peer0.beta.example.com:9051 -e CORE_PEER_LOCALMSPID="BetaMSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/beta.example.com/peers/peer0.beta.example.com/tls/ca.crt cli peer channel join -b invoice-channel.block
echo "--join peer1.beta.example.com to invoice-channel--"
docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/beta.example.com/users/Admin@beta.example.com/msp -e CORE_PEER_ADDRESS=peer1.beta.example.com:10051 -e CORE_PEER_LOCALMSPID="BetaMSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/beta.example.com/peers/peer1.beta.example.com/tls/ca.crt cli peer channel join -b invoice-channel.block

# anchor peer update
echo
echo "==================="
echo "update anchor peers"
echo "==================="
echo "--update anchor peer on Alpha--"
docker exec cli peer channel update -o orderer.example.com:7050 -c invoice-channel -f ./channel-artifacts/AlphaMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
echo "--update anchor peer on Beta--"
docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/beta.example.com/users/Admin@beta.example.com/msp -e CORE_PEER_ADDRESS=peer0.beta.example.com:9051 -e CORE_PEER_LOCALMSPID="BetaMSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/beta.example.com/peers/peer0.beta.example.com/tls/ca.crt cli peer channel update -o orderer.example.com:7050 -c invoice-channel -f ./channel-artifacts/BetaMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

