**Shopware Hosting Container**

Build image:
`
docker image build -t viosys/shopware-host .
`

Create container:
`docker run --name {container name} --link {name of the mysql container}:mysql -v {local path to shopware}:/var/www/html -e VIRTUAL_HOST={domain} -d viosys/shopware-host `

use _VIRTUAL_HOST_ if a nginx-proxy container is in use