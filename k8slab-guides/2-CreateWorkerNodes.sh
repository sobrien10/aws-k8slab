
#You can also use print-join-command to generate token and print the join command in the proper format
#COPY THIS INTO YOUR CLIPBOARD

kubeadm token create --print-join-command

#Back on the worker node c1-node1, using the Control Plane Node (API Server) IP address or name, the token and the cert has, let's join this Node to our cluster.
#Remember and add sudo to the join command

#PASTE_JOIN_COMMAND_HERE be sure to add sudo
sudo kubeadm join 172.16.94.10:6443 \
  --token yn8tkx.f5ssw0qn1ycqskt2 \
  --discovery-token-ca-cert-hash sha256:66ff307c46617ca400060e54b0db58f1597419f0a54bd971ed074b1a12067ee0 

#Log out of c1-node1 and back on to c1-cp1
exit


#Back on Control Plane Node, this will say NotReady until the networking pod is created on the new node. 
#Has to schedule the pod, then pull the container.
kubectl get nodes 


#On the Control Plane Node, watch for the calico pod and the kube-proxy to change to Running on the newly added nodes.
kubectl get pods --all-namespaces --watch


#Still on the Control Plane Node, look for this added node's status as ready.
kubectl get nodes


#GO BACK TO THE TOP AND DO THE SAME FOR c1-node2 and c1-node3
#Just SSH into c1-node2 and c1-node3 and run the commands again.

