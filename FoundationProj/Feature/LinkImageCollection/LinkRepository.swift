//
//  LinkRepository.swift
//  FoundationProj
//
//  Created by baedy on 2020/06/04.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

class LinkRepository: NSObject {
    static func getImageURL() -> [URL]{
        return [
        "https://post-phinf.pstatic.net/MjAxOTA4MzBfMjY1/MDAxNTY3MTQ5ODUyMjIz.WR3eIHPD4mcmcOptMtE0aIXFexAsKhZvTb9Ahs77ff8g.s050HZxtAJ08n5P4UHf8lYj01MYESkrhTHxA8Qz9mHMg.JPEG/04a.jpg?type=w1200"
        ,"https://images.mypetlife.co.kr/content/uploads/2019/07/12153720/cat-4265304_1920.jpg",
        "https://newsimg.hankookilbo.com/2019/04/29/201904291390027161_3.jpg",
        "https://blog.hmgjournal.com/images_n/contents/170719_cat01.png",
        "https://cdn.pixabay.com/photo/2017/02/20/18/03/cat-2083492__340.jpg",
        "https://cdn.pixabay.com/photo/2014/11/30/14/11/kitty-551554__340.jpg",
        "https://cdn.pixabay.com/photo/2018/01/28/12/37/cat-3113513__340.jpg",
        "https://cdn.pixabay.com/photo/2016/01/20/13/05/cat-1151519__340.jpg",
        "https://cdn.pixabay.com/photo/2019/05/08/21/21/cat-4189697__340.jpg",
        "https://cdn.pixabay.com/photo/2018/03/26/02/05/cat-3261420__340.jpg",
        "https://cdn.pixabay.com/photo/2013/05/17/15/54/cat-111793__340.jpg",
        "https://cdn.pixabay.com/photo/2014/10/01/16/36/siamese-468814__340.jpg",
        "https://cdn.pixabay.com/photo/2016/03/09/15/27/cat-1246659__340.jpg",
        "https://cdn.pixabay.com/photo/2018/08/08/05/12/cat-3591348__340.jpg",
        "https://cdn.pixabay.com/photo/2016/12/18/18/42/kittens-1916542__340.jpg",
        "https://cdn.pixabay.com/photo/2013/11/08/21/12/cat-207583__340.jpg",
        "https://post-phinf.pstatic.net/MjAxOTA4MzBfMjY1/MDAxNTY3MTQ5ODUyMjIz.WR3eIHPD4mcmcOptMtE0aIXFexAsKhZvTb9Ahs77ff8g.s050HZxtAJ08n5P4UHf8lYj01MYESkrhTHxA8Qz9mHMg.JPEG/04a.jpg?type=w1200",
        "https://images.mypetlife.co.kr/content/uploads/2019/07/12153720/cat-4265304_1920.jpg",
        "https://newsimg.hankookilbo.com/2019/04/29/201904291390027161_3.jpg",
        "https://blog.hmgjournal.com/images_n/contents/170719_cat01.png",
        "https://cdn.pixabay.com/photo/2017/02/20/18/03/cat-2083492__340.jpg",
        "https://cdn.pixabay.com/photo/2014/11/30/14/11/kitty-551554__340.jpg",
        "https://cdn.pixabay.com/photo/2018/01/28/12/37/cat-3113513__340.jpg",
        "https://cdn.pixabay.com/photo/2016/01/20/13/05/cat-1151519__340.jpg",
        "https://cdn.pixabay.com/photo/2019/05/08/21/21/cat-4189697__340.jpg",
        "https://cdn.pixabay.com/photo/2018/03/26/02/05/cat-3261420__340.jpg",
        "https://cdn.pixabay.com/photo/2013/05/17/15/54/cat-111793__340.jpg",
        "https://cdn.pixabay.com/photo/2014/10/01/16/36/siamese-468814__340.jpg",
        "https://cdn.pixabay.com/photo/2016/03/09/15/27/cat-1246659__340.jpg",
        "https://cdn.pixabay.com/photo/2018/08/08/05/12/cat-3591348__340.jpg",
        "https://cdn.pixabay.com/photo/2016/12/18/18/42/kittens-1916542__340.jpg",
        "https://cdn.pixabay.com/photo/2013/11/08/21/12/cat-207583__340.jpg",
        "https://post-phinf.pstatic.net/MjAxOTA4MzBfMjY1/MDAxNTY3MTQ5ODUyMjIz.WR3eIHPD4mcmcOptMtE0aIXFexAsKhZvTb9Ahs77ff8g.s050HZxtAJ08n5P4UHf8lYj01MYESkrhTHxA8Qz9mHMg.JPEG/04a.jpg?type=w1200",
        "https://images.mypetlife.co.kr/content/uploads/2019/07/12153720/cat-4265304_1920.jpg",
        "https://newsimg.hankookilbo.com/2019/04/29/201904291390027161_3.jpg",
        "https://blog.hmgjournal.com/images_n/contents/170719_cat01.png",
        "https://cdn.pixabay.com/photo/2017/02/20/18/03/cat-2083492__340.jpg",
        "https://cdn.pixabay.com/photo/2014/11/30/14/11/kitty-551554__340.jpg",
        "https://cdn.pixabay.com/photo/2018/01/28/12/37/cat-3113513__340.jpg",
        "https://cdn.pixabay.com/photo/2016/01/20/13/05/cat-1151519__340.jpg",
        "https://cdn.pixabay.com/photo/2019/05/08/21/21/cat-4189697__340.jpg",
        "https://cdn.pixabay.com/photo/2018/03/26/02/05/cat-3261420__340.jpg",
        "https://cdn.pixabay.com/photo/2013/05/17/15/54/cat-111793__340.jpg",
        "https://cdn.pixabay.com/photo/2014/10/01/16/36/siamese-468814__340.jpg",
        "https://cdn.pixabay.com/photo/2016/03/09/15/27/cat-1246659__340.jpg",
        "https://cdn.pixabay.com/photo/2018/08/08/05/12/cat-3591348__340.jpg",
        "https://cdn.pixabay.com/photo/2016/12/18/18/42/kittens-1916542__340.jpg",
        "https://cdn.pixabay.com/photo/2013/11/08/21/12/cat-207583__340.jpg"
            ].compactMap{
                URL(string: $0)
        }
    }
}
