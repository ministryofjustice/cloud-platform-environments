IMAGE := delete-oldsnapshots:1.5

all: 
	make built-image
	make push
	make clean

built-image:
	docker build -t $(IMAGE) .
	touch .built-image

push: .built-image
	docker tag $(IMAGE) ministryofjustice/$(IMAGE)
	docker push ministryofjustice/$(IMAGE)

clean:
	rm -f .built-image
	docker rm $(IMAGE)

.PHONY: .clean all
