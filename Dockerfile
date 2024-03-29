# docker build -t eb . -f .dockerfiles/Dockerfile

# FROM            계정/eb_ubuntu
FROM            yykdev/eb_ubuntu
MAINTAINER      assavictory@gmail.com

# 현재경로의 모든 파일들을 컨테이너의 /srv/deploy_eb_docker 폴더에 복사
COPY            . /srv/deploy_eb_docker

# cd /srv/deploy_eb_docker와 같은 효과
WORKDIR         /srv/deploy_eb_docker

# requirements 설치 ( debug.txt 에 기록해 둔 pip list 를 모두 install )
RUN             /root/.pyenv/versions/deploy_eb_docker/bin/pip install -r .requirements/debug.txt

# supervisor 파일 복사
COPY            .config/supervisor/uwsgi.conf /etc/supervisor/conf.d/
COPY            .config/supervisor/nginx.conf /etc/supervisor/conf.d/

COPY            .config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY            .config/nginx/nginx-app.conf /etc/nginx/sites-available/nginx-app.conf
RUN             rm -rf /etc/nginx/sites-enabled/default
RUN             ln -sf /etc/nginx/sites-available/nginx-app.conf /etc/nginx/sites-enabled/nginx-app.conf

# collectstatic 실행
RUN             /root/.pyenv/versions/deploy_eb_docker/bin/python /srv/deploy_eb_docker/django_app/manage.py collectstatic --settings=config.settings.deploy --noinput

CMD             supervisord -n
EXPOSE          80 8000

# 실행시
# docker run --rm -it -p 9000:8000 eb /bin/zsh
#
# supervisor 적용 실행시
# docker run --rm -it -p 9000:8000 eb
#
# ./manage.py runserver 0:8000 --settings=config.settings.debug

# 1. 실행중인 컨테이너의 내부에서 uwsgi를 사용해서 8000번 포트로 외부와 연결해서 Django를 실행해보기
# 2. docker run실행시 곧바로 uWSGI에 의해서 서버가 작동되도록 Dockerfile을 수정 후 build, run해보기
#   supervisor사용
# 3. uwsgi설정을 ini파일로 작성(.config/uwsgi/uwsgi-app.ini)하고
#     작성한 파일로 실행되도록 supervisor/uwsgi.conf파일을 수정
# 4. nginx설정파일, nginx사이트파일 (nginx.conf, nginx-app.conf)을 각각
#     /etc/nginx/nginx.conf, /etc/nginx/sites-available/nginx-app.conf로 복사
#    이후 링크작성 (/etc/nginx/sites-enabled/nginx-app.conf로 /etc/nginx/sites-available/nginx-app.conf를 연결)
#     /etc/nginx/sites-enabled/default 삭제
# 4-1. supervisord실행부분을 주석처리하고 docker run으로 /bin/zsh을 2개 실행 (2번째는 docker exec사용)
#       직접 nginx와 uwsgi를 실행해서 외부에서 80번포트로 잘 연결되는지 확인
#       안되면 로그확인하기
#           uwsgi: /tmp/uwsgi.log
#           nginx: /var/log/nginx/error.log


#   home에 가상환경 적용후 실행
# /root/.pyenv/versions/deploy_eb_docker/bin/uwsgi --http :8000 --chdir /srv/deploy_eb_docker/django_app --home /root/.pyenv/versions/deploy_eb_docker -w config.wsgi.debug
#
# 아래는 위 내용을 줄바꿈 처리
#
# /root/.pyenv/versions/deploy_eb_docker/bin/uwsgi \
# --http :8000 \
# --chdir /srv/deploy_eb_docker/django_app \
# --home /root/.pyenv/versions/deploy_eb_docker -w config.wsgi.debug
#
#
#cp -f /srv/deploy_ec2/.config_secret/nginx/nginx.conf /etc/nginx/nginx.conf
#cp -f /srv/deploy_ec2/.config_secret/nginx/ec2.conf /etc/nginx/sites-available
#cp -f /srv/deploy_ec2/.config_secret/uwsgi/uwsgi.service /etc/systemd/system/uwsgi.service
#ln -sf /etc/nginx/sites-available/ec2.conf /etc/nginx/sites-enabled/ec2.conf