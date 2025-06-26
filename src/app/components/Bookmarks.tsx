import { BookmarksResponse } from '@/types';
import React from 'react';
import Bookmark from '@/app/components/Bookmark';
import Pagination from '@/app/components/Pagination';

type Props = {
    bookmarks: BookmarksResponse,
    query?: string
}

const Bookmarks: React.FC<Props> = ({bookmarks, query}) => {
    return (
        <div>
            <Pagination bookmarks={bookmarks} query={query} />
            {
                bookmarks.data.map(bookmark => 
                    <Bookmark key={bookmark.id} bookmark={bookmark} />
                )
            }            
        </div>
    );
};

export default Bookmarks;