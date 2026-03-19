if [[ "$1" == "--help" ]]; then
	echo "Usage: $0 cluster-name pod-number"
	exit 0
fi

kubectl delete pvc/$1-$2 pvc/$1-$2-tbs-idxtbs pvc/$1-$2-tbs-tmptbs pvc/$1-$2-wal pod/$1-$2
