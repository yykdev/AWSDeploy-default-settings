# 배포용 프로젝트 기본 구성 저장

# 배포 할 프로젝트에 사용시 deploy용 .gitignore 사용할 것

#### 기본 프로젝트 환경 구성

```
1. pyenv virtualenv 3.6.1 instagram
2. pyenv local instagram
3. pip install django ipython django_extensions
4. django-admin startproject instagram
5. mv instagram django_app
6. pip freeze > requirements.txt
7. git init
8. cp <이전 gitignore위치> .
9. git add -A & git commit -m 'First commit'
10. Pycharm Interpreter설정
```

