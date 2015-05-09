describe JSONAPI::Serializer do
  describe 'serialize_primary_data' do
    it 'can serialize a simple object' do
      post = create(:post)
      expect(MyApp::SimplePostSerializer.serialize_primary_data(post)).to eq({
        'id' => '1',
        'type' => 'posts',
        'attributes' => {
          'title' => 'Title for Post 1',
          'long-content' => 'Body for Post 1',
        },
        'links' => {
          'self' => "/posts/1",
        },
      })
    end
    it 'can serialize a null to-one relationship' do
      post = create(:post, author: nil)
      expect(MyApp::PostSerializer.serialize_primary_data(post)).to eq({
        'id' => '1',
        'type' => 'posts',
        'attributes' => {
          'title' => 'Title for Post 1',
          'long-content' => 'Body for Post 1',
        },
        'links' => {
          'self' => "/posts/1",
          'author' => {
            'self' => "/posts/1/links/author",
            'related' => "/posts/1/author",
            # Spec: Resource linkage MUST be represented as one of the following:
            # - null for empty to-one relationships.
            # http://jsonapi.org/format/#document-structure-resource-relationships
            'linkage' => nil,
          },
          'comments' => {
            'self' => "/posts/1/links/comments",
            'related' => "/posts/1/comments",
            'linkage' => [],
          },
        },
      })
    end
    it 'can serialize a simple to-one relationship' do
      post = create(:post, :with_author)
      expect(MyApp::PostSerializer.serialize_primary_data(post)).to eq({
        'id' => '1',
        'type' => 'posts',
        'attributes' => {
          'title' => 'Title for Post 1',
          'long-content' => 'Body for Post 1',
        },
        'links' => {
          'self' => "/posts/1",
          'author' => {
            'self' => "/posts/1/links/author",
            'related' => "/posts/1/author",
            # Spec: Resource linkage MUST be represented as one of the following:
            # - a "linkage object" (defined below) for non-empty to-one relationships.
            # http://jsonapi.org/format/#document-structure-resource-relationships
            'linkage' => {
              'type' => 'users',
              'id' => '1',
            },
          },
          'comments' => {
            'self' => "/posts/1/links/comments",
            'related' => "/posts/1/comments",
            'linkage' => [],
          },
        },
      })
    end
    it 'can serialize an empty to-many relationship' do
      comments = []
      post = create(:post, comments: comments)

      expect(MyApp::PostSerializer.serialize_primary_data(post)).to eq({
        'id' => '1',
        'type' => 'posts',
        'attributes' => {
          'title' => 'Title for Post 1',
          'long-content' => 'Body for Post 1',
        },
        'links' => {
          'self' => "/posts/1",
          'author' => {
            'self' => "/posts/1/links/author",
            'related' => "/posts/1/author",
            'linkage' => nil,
          },
          'comments' => {
            'self' => "/posts/1/links/comments",
            'related' => "/posts/1/comments",
            # Spec: Resource linkage MUST be represented as one of the following:
            # - an empty array ([]) for empty to-many relationships.
            # http://jsonapi.org/format/#document-structure-resource-relationships
            'linkage' => [],
          },
        },
      })
    end
    it 'can serialize a simple to-many relationship' do
      comments = create_list(:comment, 2)
      post = create(:post, comments: comments)

      expect(MyApp::PostSerializer.serialize_primary_data(post)).to eq({
        'id' => '1',
        'type' => 'posts',
        'attributes' => {
          'title' => 'Title for Post 1',
          'long-content' => 'Body for Post 1',
        },
        'links' => {
          'self' => "/posts/1",
          'author' => {
            'self' => "/posts/1/links/author",
            'related' => "/posts/1/author",
            'linkage' => nil,
          },
          'comments' => {
            'self' => "/posts/1/links/comments",
            'related' => "/posts/1/comments",
            # Spec: Resource linkage MUST be represented as one of the following:
            # - an array of linkage objects for non-empty to-many relationships.
            # http://jsonapi.org/format/#document-structure-resource-relationships
            'linkage' => [
              {
                'type' => 'comments',
                'id' => '1',
              },
              {
                'type' => 'comments',
                'id' => '2',
              },
            ],
          },
        },
      })
    end
  end
end