# Enable the compute engine API if not already done

gcloud services enable compute.googleapis.com

# Assign project id to shell variable

export PROJECT_ID=$(gcloud config list --format 'value(core.project)')

# # Create GCS bucket and copy images to bucket - NOT USED

# gsutil mb -l australia-southeast1 gs://$PROJECT_ID-images

# gsutil -m cp -r gs://omega-vector-398906-images/* gs://$PROJECT_ID-images/


# # Make bucket objects public

# gsutil defacl ch -u AllUsers:R gs://$PROJECT_ID-images

# Create firewall rules allowing http and load balancer/health check access

gcloud compute firewall-rules create http-allow --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

gcloud compute firewall-rules create health-check-allow --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp --source-ranges=130.211.0.0/22,35.191.0.0/16 --target-tags=http-server

# create CDN demo instance template

gcloud compute instance-templates create cdn-demo-template --machine-type=f1-micro --metadata=startup-script-url=gs://natural-treat-425401-f5-script/website-script/cdn-website-script.sh --tags=http-server --boot-disk-device-name=cdn-demo-template


# create health check and instance groups from cdn demo template

gcloud compute health-checks create tcp "health-check" --timeout "5" --check-interval "10" --unhealthy-threshold "3" --healthy-threshold "2" --port "80"

# Create Instance Groups 
gcloud beta compute instance-groups managed create australia-southeast1-group --base-instance-name=australia-southeast1-group --template=cdn-demo-template --size=3 --zones=australia-southeast1-a,australia-southeast1-b,australia-southeast1-c --instance-redistribution-type=PROACTIVE --health-check=health-check --initial-delay=300


# Set up HTTP Load Balancer
# set named ports for instance groups

gcloud compute instance-groups managed set-named-ports australia-southeast1-group \
    --named-ports http:80 \
    --region australia-southeast1

# create backend service and add backends

gcloud compute backend-services create http-backend \
    --protocol HTTP \
    --health-checks health-check \
    --global

gcloud compute backend-services add-backend http-backend \
    --balancing-mode=RATE \
    --max-rate-per-instance=50 \
    --capacity-scaler=1 \
    --instance-group=australia-southeast1-group \
    --instance-group-region=australia-southeast1 \
    --global

#create lb

gcloud compute url-maps create http-lb \
    --default-service http-backend

gcloud compute target-http-proxies create http-lb-proxy \
    --url-map=http-lb

gcloud compute forwarding-rules create http-frontend \
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80

# Create testing instance in us-central1 region

gcloud compute instances create testing-instance --zone us-central1-b --machine-type f1-micro

# Get frontend IP address and assign it to a shell variable

for FRONTEND in $(gcloud compute forwarding-rules describe http-frontend --format="get(IPAddress)" --global)
do
  gcloud compute forwarding-rules describe http-frontend --format="get(IPAddress)" --global
done

clear

echo -------------------------------
echo "Script complete, wait about 5 minutes for your load balancer to initialize, then access frontend address in a new tab"
echo "Your load balancer frontend IP address is" $FRONTEND
echo "If you receive an error for the website, wait a few more minutes and try again"
echo -------------------------------


krish2024d3@testing-instance:~$ for i in {1..15};do curl -s -w "%{time_total}\n" -o /dev/null http://130.211.32.107/page-2.html; done
0.179667
0.180144
0.180031
0.179241
0.183520
0.177834
0.178880
0.179016
0.178126
0.181308
0.180033
0.179127
0.180860
0.181234
0.173308

0.003043
0.002224
0.004792
0.002920
0.002746
0.002138
0.002535
0.002734
0.003395
0.003134
0.002462
0.002824
0.003894
0.002076
0.002540