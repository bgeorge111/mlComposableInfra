DATA_HUB_HOME="/home/data-hub"
UTILITIES_HOME="/home/data-hub-utilities"
CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED"
_HUB_CENTRAL_WAR=`cat /tmp/installEnv.env | grep _HUB_CENTRAL_WAR | cut -d'=' -f2`
_HUB_CENTRAL_CE_WAR=`cat /tmp/installEnv.env | grep _HUB_CE_CENTRAL_WAR | cut -d'=' -f2`
_MLCP_ZIP=`cat /tmp/installEnv.env | grep _MLCP_ZIP | cut -d'=' -f2`
_MLCP_VERSION=`cat /tmp/installEnv.env | grep _MLCP_VERSION | cut -d'=' -f2`
_GRADLE_ZIP=`cat /tmp/installEnv.env | grep _GRADLE_ZIP | cut -d'=' -f2`
_GRADLE_VERSION=`cat /tmp/installEnv.env | grep _GRADLE_VERSION | cut -d'=' -f2`
_DATA_HUB_VERSION=`cat /tmp/installEnv.env | grep _DATA_HUB_VERSION | cut -d'=' -f2`
_ML_ADMIN_USERNAME=`cat /tmp/installEnv.env | grep _ML_ADMIN_USERNAME | cut -d'=' -f2`
_ML_ADMIN_PASSWORD=`cat /tmp/installEnv.env | grep _ML_ADMIN_PASSWORD | cut -d'=' -f2`
if [ ! -e /tmp/$CONTAINER_ALREADY_STARTED ]; then
	yum install -y unzip
	yum install -y java-1.8.0-openjdk-devel
	yum clean all
	mkdir -p $DATA_HUB_HOME
	mkdir -p $UTILITIES_HOME
	cp /tmp/$_HUB_CENTRAL_WAR $UTILITIES_HOME
	cp /tmp/$_HUB_CENTRAL_CE_WAR $UTILITIES_HOME
	cp /tmp/$_MLCP_ZIP $UTILITIES_HOME
	unzip -d /opt/gradle -o /tmp/$_GRADLE_ZIP
	export JAVA_HOME=/etc/alternatives/java_sdk_1.8.0_openjdk
	export GRADLE_HOME=/opt/gradle/gradle-$_GRADLE_VERSION
	export PATH=$GRADLE_HOME/bin:$JAVA_HOME:$JAVA_HOME/bin:$PATH
	export MLCP=$UTILITIES_HOME/mlcp-$_MLCP_VERSION/bin
	export PATH=$MLCP:$PATH
	cd $UTILITIES_HOME
	unzip -o $UTILITIES_HOME/mlcp-$_MLCP_VERSION-bin.zip -d $UTILITIES_HOME
	rm -f $UTILITIES_HOME/mlcp-$_MLCP_VERSION-bin.zip
	cat <<EOF > $DATA_HUB_HOME/build.gradle
		plugins {
		  // Gradle Properties plugin
		  id 'net.saliman.properties' version '1.4.6'

		  // Data Hub plugin
		  id 'com.marklogic.ml-data-hub' version '$_DATA_HUB_VERSION'
	  }
EOF
	cd $DATA_HUB_HOME
	gradle hubInit -i
	cat <<EOF > $DATA_HUB_HOME/src/main/ml-config/security/users/hc-dev1.json
		 {
	  "user-name": "hc-default",
	  "description": "Hub Central Default user",
	  "password": "MarkLogic*001",
	  "role": [
		"hub-central-developer",
		"data-hub-developer",
		"pii-reader",
		"qconsole-user",
		"ort-user"
	  ]
	}
EOF
	sed -i 's/mlHost=localhost/mlHost=marklogic1/g' gradle.properties
	sed -i 's/mlUsername=/mlUsername='$_ML_ADMIN_USERNAME'/g' gradle.properties
	sed -i 's/mlPassword=/mlPassword='$_ML_ADMIN_PASSWORD'/g' gradle.properties
	gradle mlDeploy -i
	cd $UTILITIES_HOME
	echo "Starting Hub Central..."
	nohup java -jar $_HUB_CENTRAL_WAR  --spring.config.additional-location=file:/home/data-hub/gradle.properties > /tmp/hc.log &
	nohup java -jar $_HUB_CENTRAL_CE_WAR  --spring.config.additional-location=file:/home/data-hub/gradle.properties > /tmp/hcce.log &
    touch /tmp/$CONTAINER_ALREADY_STARTED	
else 
	echo "-- Not first container startup. Everything is retained. only starting HC & HCCE --"
	export JAVA_HOME=/etc/alternatives/java_sdk_1.8.0_openjdk
	export GRADLE_HOME=/opt/gradle/gradle-$_GRADLE_VERSION
	export PATH=$GRADLE_HOME/bin:$JAVA_HOME:$JAVA_HOME/bin:$PATH
	export MLCP=$UTILITIES_HOME/mlcp-$_MLCP_VERSION/bin
	export PATH=$MLCP:$PATH
	cd $UTILITIES_HOME
	echo "Starting Hub Central..."
	nohup java -jar  $_HUB_CENTRAL_WAR  --spring.config.additional-location=file:/home/data-hub/gradle.properties > /tmp/hc.log & 
	nohup java -jar  $_HUB_CENTRAL_CE_WAR  --spring.config.additional-location=file:/home/data-hub/gradle.properties > /tmp/hcce.log & 
fi