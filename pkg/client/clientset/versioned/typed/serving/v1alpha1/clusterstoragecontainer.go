/*
Copyright 2023 The KServe Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Code generated by client-gen. DO NOT EDIT.

package v1alpha1

import (
	context "context"

	servingv1alpha1 "github.com/kserve/kserve/pkg/apis/serving/v1alpha1"
	scheme "github.com/kserve/kserve/pkg/client/clientset/versioned/scheme"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	types "k8s.io/apimachinery/pkg/types"
	watch "k8s.io/apimachinery/pkg/watch"
	gentype "k8s.io/client-go/gentype"
)

// ClusterStorageContainersGetter has a method to return a ClusterStorageContainerInterface.
// A group's client should implement this interface.
type ClusterStorageContainersGetter interface {
	ClusterStorageContainers(namespace string) ClusterStorageContainerInterface
}

// ClusterStorageContainerInterface has methods to work with ClusterStorageContainer resources.
type ClusterStorageContainerInterface interface {
	Create(ctx context.Context, clusterStorageContainer *servingv1alpha1.ClusterStorageContainer, opts v1.CreateOptions) (*servingv1alpha1.ClusterStorageContainer, error)
	Update(ctx context.Context, clusterStorageContainer *servingv1alpha1.ClusterStorageContainer, opts v1.UpdateOptions) (*servingv1alpha1.ClusterStorageContainer, error)
	Delete(ctx context.Context, name string, opts v1.DeleteOptions) error
	DeleteCollection(ctx context.Context, opts v1.DeleteOptions, listOpts v1.ListOptions) error
	Get(ctx context.Context, name string, opts v1.GetOptions) (*servingv1alpha1.ClusterStorageContainer, error)
	List(ctx context.Context, opts v1.ListOptions) (*servingv1alpha1.ClusterStorageContainerList, error)
	Watch(ctx context.Context, opts v1.ListOptions) (watch.Interface, error)
	Patch(ctx context.Context, name string, pt types.PatchType, data []byte, opts v1.PatchOptions, subresources ...string) (result *servingv1alpha1.ClusterStorageContainer, err error)
	ClusterStorageContainerExpansion
}

// clusterStorageContainers implements ClusterStorageContainerInterface
type clusterStorageContainers struct {
	*gentype.ClientWithList[*servingv1alpha1.ClusterStorageContainer, *servingv1alpha1.ClusterStorageContainerList]
}

// newClusterStorageContainers returns a ClusterStorageContainers
func newClusterStorageContainers(c *ServingV1alpha1Client, namespace string) *clusterStorageContainers {
	return &clusterStorageContainers{
		gentype.NewClientWithList[*servingv1alpha1.ClusterStorageContainer, *servingv1alpha1.ClusterStorageContainerList](
			"clusterstoragecontainers",
			c.RESTClient(),
			scheme.ParameterCodec,
			namespace,
			func() *servingv1alpha1.ClusterStorageContainer { return &servingv1alpha1.ClusterStorageContainer{} },
			func() *servingv1alpha1.ClusterStorageContainerList {
				return &servingv1alpha1.ClusterStorageContainerList{}
			},
		),
	}
}
